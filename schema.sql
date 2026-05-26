-- 1. Create the dedicated schema namespace
CREATE SCHEMA IF NOT EXISTS ticket_queue;

-- 2. Create the main task queue table
CREATE TABLE ticket_queue.tickets (
    id SERIAL PRIMARY KEY,
    ticket_id VARCHAR(50) NOT NULL,
    requester_email VARCHAR(255),
    context VARCHAR(100),
    status VARCHAR(20) DEFAULT 'new' CHECK (status IN ('new', 'running', 'completed', 'failed')),
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexing for optimized polling performance (avoids full-table scans every 6 seconds)
CREATE INDEX idx_tickets_status_submitted ON ticket_queue.tickets (status, submitted_at);

-- 3. Create the Load Balancer control table
CREATE TABLE ticket_queue.load_balancer (
    id INT PRIMARY KEY DEFAULT 1,
    current_instance INT DEFAULT 1,
    total_instances INT DEFAULT 4,
    -- This constraint guarantees that only ONE row can ever exist in this table
    CONSTRAINT chk_single_row CHECK (id = 1) 
);

-- 4. Seed the initial state for the load balancer
INSERT INTO ticket_queue.load_balancer (id, current_instance, total_instances)
VALUES (1, 1, 4)
ON CONFLICT (id) DO NOTHING;