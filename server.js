const express = require("express");
const cors = require("cors");
const { v4: uuidv4 } = require("uuid");
const http = require("http");
const app = express();
const server = http.createServer(app);
const io = require("socket.io")(server, {
  cors: { origin: "*", methods: ["GET", "POST", "PUT"] }
});

app.use(cors());
app.use(express.json());

// In-memory DB
let requests = [];

/* ----------------- SOCKET ROOMS -----------------
   - Receivers join room: "receiver"
   - End users join room: `user:<userId>`
-------------------------------------------------*/
io.on("connection", (socket) => {
  const { role, userId } = socket.handshake.query || {};
  if (role === "receiver") socket.join("receiver");
  if (role === "enduser" && userId) socket.join(`user:${userId}`);
  socket.emit("connected", { ok: true, role, userId });
});

/* ----------------- REST ENDPOINTS ----------------*/

// Create request (End User)
app.post("/requests", (req, res) => {
  const { userId, items } = req.body;
  const newRequest = {
    id: uuidv4(),
    userId,
    items: (items || []).map(i => ({ id: uuidv4(), name: i.name, status: "Pending" })),
    status: "Pending",
    createdAt: Date.now()
  };
  requests.push(newRequest);

  // Notify both receivers & that user
  io.to("receiver").emit("request_created", newRequest);
  io.to(`user:${userId}`).emit("request_created", newRequest);

  res.status(201).json(newRequest);
});

// Fetch requests (role-based)
app.get("/requests", (req, res) => {
  const { role, userId } = req.query;
  if (role === "enduser") return res.json(requests.filter(r => r.userId === userId));
  if (role === "receiver") return res.json(requests);
  res.status(400).json({ error: "Invalid role" });
});

// Confirm item (Receiver)
app.put("/requests/confirm", (req, res) => {
  const { requestId, itemId, available } = req.body;
  const request = requests.find(r => r.id === requestId);
  if (!request) return res.status(404).json({ error: "Request not found" });

  const item = request.items.find(i => i.id === itemId);
  if (!item) return res.status(404).json({ error: "Item not found" });

  item.status = available ? "Confirmed" : "Unconfirmed";

  const allConfirmed = request.items.every(i => i.status === "Confirmed");
  const someConfirmed = request.items.some(i => i.status === "Confirmed");

  if (allConfirmed) request.status = "Confirmed";
  else if (someConfirmed) request.status = "Partially Fulfilled";
  else request.status = "Pending";

  // Notify both receivers & that user
  io.to("receiver").emit("request_updated", request);
  io.to(`user:${request.userId}`).emit("request_updated", request);

  res.json(request);
});

const PORT = 5000;
server.listen(PORT, () => console.log(`Server & Socket.IO on http://localhost:${PORT}`));
