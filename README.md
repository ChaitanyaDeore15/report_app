Request Handling Workflow Prototype

This project implements a request and confirmation workflow using Flutter (frontend) and Node.js/Express + Socket.IO (backend).
It supports two roles:

End User → submits requests containing multiple items.

Receiver → reviews requests and confirms/rejects items one by one.

Statuses: Pending, Confirmed, Partially Fulfilled.
Real-time updates are delivered via Socket.IO (WebSockets).

🚀 Setup Instructions
1. Clone the repository
git clone https://github.com/your-username/report.git
cd report

2. Backend Setup
cd backend
npm install
node server.js


Backend runs at:

http://localhost:5000


👉 Notes:

Android Emulator connects to backend using http://10.0.2.2:5000.

iOS Simulator can use http://localhost:5000.

Physical device → replace with your PC’s IP (e.g., http://192.168.1.5:5000).

3. Flutter Setup
cd ..
flutter pub get
flutter run

4. Run Order

Start backend (node server.js)

Run Flutter app (flutter run)

Login:

End User → enter a User ID, create requests.

Receiver → review requests, confirm/reject items.

Watch real-time updates flow across both roles.

⚙️ System Design & Approach
Architecture

Flutter (Frontend)

Handles UI for both roles (End User & Receiver).

Uses Riverpod for state management.

Uses http for REST API calls.

Uses socket_io_client for WebSocket real-time updates.

Node.js + Express (Backend)

Manages requests in memory (can be replaced with DB).

Provides REST endpoints for creating/fetching/updating requests.

Uses Socket.IO to push updates instantly to connected clients.

Workflow

End User creates request → backend stores it → notifies via Socket.IO.

Receiver reviews request → confirms/rejects items.

Backend updates status:

All items confirmed → Confirmed

Some confirmed → Partially Fulfilled

None confirmed → stays Pending

Both clients receive updates in real-time.

Error Handling

If Socket.IO connection fails, app falls back to manual API refresh.

Network errors are caught and printed in logs.

Minimal UI ensures clarity of workflow.

📡 API Endpoints
1. Create Request

POST /requests
Request body:

{
  "userId": "user123",
  "items": [
    { "name": "Item A" },
    { "name": "Item B" }
  ]
}


Response:

{
  "id": "req-uuid",
  "userId": "user123",
  "items": [
    { "id": "item-uuid", "name": "Item A", "status": "Pending" },
    { "id": "item-uuid", "name": "Item B", "status": "Pending" }
  ],
  "status": "Pending"
}

2. Fetch Requests

GET /requests?role=enduser&userId=user123
GET /requests?role=receiver

Response:

[
  {
    "id": "req-uuid",
    "userId": "user123",
    "items": [
      { "id": "item-uuid", "name": "Item A", "status": "Confirmed" },
      { "id": "item-uuid", "name": "Item B", "status": "Unconfirmed" }
    ],
    "status": "Partially Fulfilled"
  }
]

3. Confirm/Reject Item

PUT /requests/confirm
Request body:

{
  "requestId": "req-uuid",
  "itemId": "item-uuid",
  "available": true
}


Response:

{
  "id": "req-uuid",
  "userId": "user123",
  "items": [
    { "id": "item-uuid", "name": "Item A", "status": "Confirmed" },
    { "id": "item-uuid", "name": "Item B", "status": "Unconfirmed" }
  ],
  "status": "Partially Fulfilled"
}

✅ Features Implemented

End User can submit requests with multiple items.

Receiver can confirm/reject items.

Status updates: Pending / Confirmed / Partially Fulfilled.

Real-time updates with Socket.IO.

Fallback to manual refresh if sockets fail.

Clean UI with Riverpod state management.
