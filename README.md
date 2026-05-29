# n8n Multi-Agent Workflow Load Balancer

An enterprise-grade, state-driven orchestration and queue management pattern for distributed AI agent execution inside n8n. This project implements a **state-driven queue and round-robin load balancer** using PostgreSQL to safely distribute tasks across up to 4 parallel autonomous agent runtimes

> 💡 **Note:** This repository serves as a proof of concept (PoC) and architectural blueprint to demonstrate state-driven queue management and round-robin load balancing within n8n. Feel free to use this pattern as a foundational reference to build and adapt your own production-grade automation pipelines.

---
 
## 🚀 Features

* **Round-Robin Distribution:** Uses atomic database counters and modulo arithmetic (`(current_instance % total_instances) + 1`) to evenly distribute incoming jobs.
* **Concurrency Control & Deduplication:** Auto-detects and purges duplicate webhook triggers or rapid-fire ticket requests to save LLM tokens.
* **Stuck-State Recovery:** Automatically cleans up or alerts on executions that have been sitting in a `running` state for more than 2 hours.
* **Data Validation:** Drops malformed payloads (e.g., short or invalid ticket IDs) early to maintain pipeline health.

## 📁 Repository Structure

```text
n8n-agent-load-balancer/
├── agent-load-balancer-workflow.json
├── schema.sql
├── n8n-workflow-screenshot.png
└── README.md

```
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
Execute the table structures, indexes, and initial configuration seeds in your target PostgreSQL database instance using the provided initialization file.

👉 Run the scripts found in: **[`schema.sql`](./schema.sql)**

### 2. Import & Configure the Workflow
1. Copy or download the workflow JSON configuration file: **[`agent-load-balancer-workflow.json`](./agent-load-balancer-workflow.json)**
2. Open your n8n instance, create a new workflow, and click **Import from File** in the top-right menu (or paste the JSON raw data directly onto the canvas).
3. Configure your **PostgreSQL Credentials** on the database nodes to point to your live instance.

> ⚠️ **Critical Step (Environment Sanitization):** Before activating the workflow, make sure to search for and update all placeholders containing `<...>` formatting. You must replace them with your own environment data, including custom target workflow IDs (for sub-workflow nodes), agent webhook URLs, agent identifiers and API keys.


### 3. Scaling the Instances
If you want to scale out to a 5th or 6th agent runtime, simply update the `total_instances` parameter in your load balancer configuration table:

```sql
UPDATE ticket_queue.load_balancer 
SET total_instances = 5 
WHERE id = 1;

```

## 📄 License

This project is proprietary and confidential. All rights intellectual and material property belong exclusively to **Entry LLC**. 

Authorized personnel may access this repository for evaluation and maintenance purposes subject to company NDAs. Any unauthorized copying, distribution, alteration, or usage of this software via any medium is strictly prohibited.

For complete legal terms and compliance metrics, please refer to the main [LICENSE](LICENSE) file.
