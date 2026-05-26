# n8n Multi-Agent Workflow Load Balancer

An enterprise-grade, state-driven orchestration and queue management pattern for distributed AI agent execution inside n8n. This project implements a **state-driven queue and round-robin load balancer** using PostgreSQL to safely distribute tasks across up to 4 parallel autonomous agent runtimes

## 🚀 Features

* **Round-Robin Distribution:** Uses atomic database counters and modulo arithmetic (`(current_instance % total_instances) + 1`) to evenly distribute incoming jobs.
* **Concurrency Control & Deduplication:** Auto-detects and purges duplicate webhook triggers or rapid-fire ticket requests to save LLM tokens.
* **Stuck-State Recovery:** Automatically cleans up or alerts on executions that have been sitting in a `running` state for more than 2 hours.
* **Data Validation:** Drops malformed payloads (e.g., short or invalid ticket IDs) early to maintain pipeline health.

---

## 📐 How It Works

```text
   [ Schedule Trigger ] (Every 6s)
            │
            ▼
┌───────────────────────┐
│  Get Oldest 'new' Job │
└───────────┬───────────┘
            │
            ├─► [Validation / Duplicate Check] ──► (Purge / Alert)
            │
            ▼
┌───────────────────────┐
│ Set Status='running'  │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│ Read & Advance Index  │ ──► Modulo: (current % total) + 1
└───────────┬───────────┘
            │
            ▼
   [ Switch Node ]
     ├── Route 1 ──► Local Workflow (Jamie)
     ├── Route 2 ──► HTTP Webhook (Second Gear)
     ├── Route 3 ──► HTTP Webhook (MCP Jamie)
     └── Route 4 ──► HTTP Webhook (Jamie Quad)


```
---

## 🛠️ Setup Instructions

### 1. Database Setup
Execute the following SQL structure in your PostgreSQL database instance to provision the required tables, seed data, and enforce integrity constraints.

*See [schema.sql](./schema.sql) for details.*

### 2. Import the Workflow
1. Download the JSON file from the `/workflows` directory.
2. Open your n8n instance, create a new workflow, and click **Import from File** in the top right menu.
3. Configure your **PostgreSQL Credentials** on the database nodes.

### 3. Scaling the Instances
If you want to scale out to a 5th or 6th agent runtime, simply update the `total_instances` parameter in your load balancer configuration table:

```sql
UPDATE ticket_queue.load_balancer 
SET total_instances = 5 
WHERE id = 1;

```

## 📄 License
This project is licensed under the MIT License.
