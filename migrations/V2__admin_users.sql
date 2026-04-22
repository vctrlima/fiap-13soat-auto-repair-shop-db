-- V2__admin_users.sql
-- Adds the `admins` table to customer_vehicle_db.
-- Admin users authenticate via email+password (POST /api/auth/login).
-- Customer users authenticate via CPF (POST /api/auth/cpf).
-- These are two distinct identity domains.
CREATE TABLE "public"."Admin" (
    "id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "email" VARCHAR(100) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "role" VARCHAR(20) NOT NULL DEFAULT 'ADMIN',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),
    CONSTRAINT "Admin_pkey" PRIMARY KEY ("id")
);

-- Email must be unique (used as login identifier)
CREATE UNIQUE INDEX "Admin_email_key" ON "public"."Admin"("email");

CREATE INDEX "admin_created_at_idx" ON "public"."Admin"("created_at");

-- ─── Refresh Tokens (for admin token rotation) ────────────────────────────────
CREATE TABLE "public"."AdminRefreshToken" (
    "jti" VARCHAR(36) NOT NULL,
    "admin_id" UUID NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "AdminRefreshToken_pkey" PRIMARY KEY ("jti"),
    CONSTRAINT "AdminRefreshToken_admin_id_fkey" FOREIGN KEY ("admin_id") REFERENCES "public"."Admin"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "refresh_token_admin_id_idx" ON "public"."AdminRefreshToken"("admin_id");

CREATE INDEX "refresh_token_expires_at_idx" ON "public"."AdminRefreshToken"("expires_at");