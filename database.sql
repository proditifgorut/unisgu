-- UNISGU Database Schema
-- PostgreSQL Syntax (Compatible with Supabase)

-- ----------------------------
-- Section 1: User Management & Authentication
-- ----------------------------

-- Users Table
-- Stores user information, roles, and credentials.
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    avatar_url TEXT,
    phone_number VARCHAR(20),
    role VARCHAR(50) NOT NULL DEFAULT 'user', -- e.g., 'user', 'admin', 'premium_member'
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE users IS 'Stores user accounts and profile information.';
COMMENT ON COLUMN users.role IS 'Defines user permissions (e.g., user, admin, premium_member).';

-- ----------------------------
-- Section 2: Memberships & Services
-- ----------------------------

-- Memberships Table
-- Defines the available premium membership plans.
CREATE TABLE memberships (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price_per_month NUMERIC(10, 2) NOT NULL,
    duration_months INT NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL,
    is_popular BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE memberships IS 'Defines the premium membership packages.';

-- User Memberships Table
-- Links users to their active or past membership plans.
CREATE TABLE user_memberships (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    membership_id INT NOT NULL REFERENCES memberships(id) ON DELETE RESTRICT,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'active', -- 'active', 'expired', 'cancelled'
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE user_memberships IS 'Tracks which users have subscribed to which memberships.';

-- Services Table
-- Defines the professional services offered by the community.
CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    starting_price NUMERIC(10, 2),
    price_unit VARCHAR(50) DEFAULT 'project', -- e.g., 'project', 'hour', 'month'
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE services IS 'Lists all professional services offered.';

-- ----------------------------
-- Section 3: Orders & Payments
-- ----------------------------

-- Orders Table
-- Records every transaction made by a user.
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_amount NUMERIC(10, 2) NOT NULL,
    tax_amount NUMERIC(10, 2) NOT NULL,
    final_amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'completed', 'failed'
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE orders IS 'Main table for tracking customer orders.';

-- Order Items Table
-- Details the items within each order.
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    service_id INT REFERENCES services(id) ON DELETE SET NULL,
    membership_id INT REFERENCES memberships(id) ON DELETE SET NULL,
    item_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price NUMERIC(10, 2) NOT NULL
);

COMMENT ON TABLE order_items IS 'Line items for each order.';

-- Projects Table
-- Manages the lifecycle of ordered professional services.
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_id INT NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    service_id INT NOT NULL REFERENCES services(id) ON DELETE RESTRICT,
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'in_progress', 'reviewing', 'completed', 'cancelled'
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE projects IS 'Tracks the status of professional services ordered by users.';

-- ----------------------------
-- Section 4: Learning Management System (LMS)
-- ----------------------------

-- Learning Paths Table
-- Defines high-level learning tracks (e.g., Fullstack Web).
CREATE TABLE learning_paths (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE learning_paths IS 'Defines the main learning programs, like Fullstack Web Dev.';

-- Modules Table
-- Groups lessons into modules within a learning path.
CREATE TABLE modules (
    id SERIAL PRIMARY KEY,
    learning_path_id INT NOT NULL REFERENCES learning_paths(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    module_order INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE modules IS 'A collection of lessons within a learning path.';

-- Lessons Table
-- Stores individual lesson content.
CREATE TABLE lessons (
    id SERIAL PRIMARY KEY,
    module_id INT NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    video_url TEXT,
    content TEXT,
    lesson_order INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE lessons IS 'Individual learning units with video and text content.';

-- User Progress Table
-- Tracks a user's completion status for each lesson.
CREATE TABLE user_progress (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id INT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'not_started', -- 'not_started', 'in_progress', 'completed'
    completed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, lesson_id)
);

COMMENT ON TABLE user_progress IS 'Tracks which lessons a user has completed.';

-- ----------------------------
-- Section 5: Website Content
-- ----------------------------

-- Contacts Table
-- Stores messages submitted through the contact form.
CREATE TABLE contacts (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    subject VARCHAR(255),
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE contacts IS 'Stores submissions from the website contact form.';


-- ----------------------------
-- Section 6: Initial Data Seeding
-- ----------------------------

-- Insert Default Users
-- IMPORTANT: Replace 'hashed_password_placeholder' with a securely hashed password.
INSERT INTO users (email, password_hash, full_name, role) VALUES
('admin@admin.com', 'hashed_password_placeholder', 'Admin User', 'admin'),
('user@user.com', 'hashed_password_placeholder', 'Budi Santoso', 'premium_member');

-- Insert Services
INSERT INTO services (name, description, starting_price, price_unit) VALUES
('Pengembangan Website', 'Pembuatan website profesional untuk bisnis, UMKM, institusi, dan lembaga dengan teknologi modern, cepat, dan aman.', 3000000, 'project'),
('Instalasi Open Journal Systems (OJS)', 'Layanan instalasi, konfigurasi, dan maintenance OJS untuk penerbitan jurnal ilmiah Anda secara profesional.', 1500000, 'project'),
('Manajemen Server & VPS', 'Instalasi dan optimasi VPS, termasuk setup aaPanel, Nginx, dan konfigurasi keamanan untuk performa maksimal.', 500000, 'month'),
('Pendampingan Publikasi Ilmiah', 'Bantuan publikasi dari submit hingga terbit di SINTA (1-6) dan Scopus (Q2 & Q3), termasuk formatting dan proofreading.', 4000000, 'project'),
('Jasa Penulisan Buku', 'Kami membantu penulisan dan penerbitan buku ajar, buku referensi, dan monograf, lengkap dengan ISBN dan desain cover.', 7000000, 'project'),
('Konsultasi Teknologi', 'Butuh saran ahli untuk proyek digital Anda? Tim kami siap membantu Anda menemukan solusi teknologi yang tepat.', 400000, 'hour');

-- Insert Memberships
INSERT INTO memberships (name, description, price_per_month, duration_months, total_price, is_popular) VALUES
('Paket Bulanan', 'Fleksibel, cocok untuk mencoba.', 2500000, 1, 2500000, false),
('Paket 3 Bulan', 'Kombinasi terbaik untuk hasil optimal.', 1800000, 3, 5400000, true),
('Paket 6 Bulan', 'Komitmen penuh untuk transformasi karir.', 1500000, 6, 9000000, false);

-- Insert Learning Paths
INSERT INTO learning_paths (title, description) VALUES
('Fullstack Website Developer', 'Kuasai seni membangun aplikasi web modern dari front-end hingga back-end, database, dan deployment.'),
('Fullstack Mobile Developer', 'Bangun aplikasi mobile cross-platform yang andal, dari desain UI/UX hingga integrasi API dan publikasi ke app store.');

-- Insert Modules and Lessons for Web Dev Path
WITH web_path AS (SELECT id FROM learning_paths WHERE title = 'Fullstack Website Developer')
INSERT INTO modules (learning_path_id, title, module_order) VALUES
((SELECT id FROM web_path), 'Modul 1: Frontend Dasar', 1),
((SELECT id FROM web_path), 'Modul 2: React.js', 2),
((SELECT id FROM web_path), 'Modul 3: Backend dengan Node.js', 3);

WITH web_module1 AS (SELECT id FROM modules WHERE title = 'Modul 1: Frontend Dasar')
INSERT INTO lessons (module_id, title, video_url, content, lesson_order) VALUES
(web_module1, 'HTML & CSS Lanjutan', 'https://www.youtube.com/embed/...', 'Konten tentang HTML & CSS.', 1),
(web_module1, 'JavaScript Modern (ES6+)', 'https://www.youtube.com/embed/...', 'Konten tentang ES6+.', 2);

WITH web_module2 AS (SELECT id FROM modules WHERE title = 'Modul 2: React.js')
INSERT INTO lessons (module_id, title, video_url, content, lesson_order) VALUES
(web_module2, 'Komponen & Props', 'https://www.youtube.com/embed/...', 'Konten tentang React Components.', 1),
(web_module2, 'State & Lifecycle', 'https://www.youtube.com/embed/...', 'Konten tentang React State.', 2);

WITH web_module3 AS (SELECT id FROM modules WHERE title = 'Modul 3: Backend dengan Node.js')
INSERT INTO lessons (module_id, title, video_url, content, lesson_order) VALUES
(web_module3, 'Pengenalan Node.js', 'https://www.youtube.com/embed/f2EqECiTBL8', 'Konten tentang Node.js.', 1),
(web_module3, 'Express.js', 'https://www.youtube.com/embed/...', 'Konten tentang Express.js.', 2),
(web_module3, 'REST API', 'https://www.youtube.com/embed/...', 'Konten tentang REST API.', 3);

-- End of Schema
