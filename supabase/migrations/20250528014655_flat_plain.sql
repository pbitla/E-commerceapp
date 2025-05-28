/*
  # Enhanced E-commerce Schema Update

  1. New Tables
    - admins: Admin user management
    - admin_permissions: Role-based access control
    - payment_details: Secure payment information
    - notifications: User notifications
    - coupons: Discount management
    - templates: Email/SMS templates

  2. Updates
    - Enhanced user profiles
    - Added audit logs
    - Improved order management
*/

-- Admin Management
CREATE TABLE ecommerce.admins (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  role text NOT NULL,
  status text NOT NULL DEFAULT 'active',
  last_login timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE ecommerce.admin_permissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id uuid REFERENCES ecommerce.admins(id) ON DELETE CASCADE,
  permission text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Payment Management
CREATE TABLE ecommerce.payment_details (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES ecommerce.orders(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  payment_method text NOT NULL,
  card_type text,
  card_last4 text,
  card_expiry text,
  cardholder_name text,
  payment_status text NOT NULL,
  transaction_id text UNIQUE,
  amount numeric NOT NULL CHECK (amount >= 0),
  currency text NOT NULL DEFAULT 'USD',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Notifications
CREATE TABLE ecommerce.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  type text NOT NULL,
  message text NOT NULL,
  status text NOT NULL DEFAULT 'unread',
  created_at timestamptz DEFAULT now()
);

-- Coupons
CREATE TABLE ecommerce.coupons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text UNIQUE NOT NULL,
  discount_type text NOT NULL,
  discount_value numeric NOT NULL,
  expiry timestamptz NOT NULL,
  usage_limit integer,
  times_used integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Templates
CREATE TABLE ecommerce.templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text NOT NULL,
  name text NOT NULL,
  content text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Audit Logs
CREATE TABLE ecommerce.audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id uuid REFERENCES ecommerce.admins(id) ON DELETE SET NULL,
  action text NOT NULL,
  table_name text NOT NULL,
  record_id uuid NOT NULL,
  changes jsonb,
  created_at timestamptz DEFAULT now()
);

-- Add columns to existing tables
ALTER TABLE ecommerce.orders
ADD COLUMN address_id uuid REFERENCES auth.users(id),
ADD COLUMN coupon_id uuid REFERENCES ecommerce.coupons(id),
ADD COLUMN shipping_method text,
ADD COLUMN tracking_number text;

-- Enable RLS on new tables
ALTER TABLE ecommerce.payment_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE ecommerce.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE ecommerce.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE ecommerce.templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE ecommerce.audit_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies for new tables
CREATE POLICY "Users can view own payment details"
  ON ecommerce.payment_details FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can view own notifications"
  ON ecommerce.notifications FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Public can use valid coupons"
  ON ecommerce.coupons FOR SELECT
  TO public
  USING (expiry > now() AND (usage_limit IS NULL OR times_used < usage_limit));

-- Functions for audit logging
CREATE OR REPLACE FUNCTION ecommerce.create_audit_log()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO ecommerce.audit_logs (admin_id, action, table_name, record_id, changes)
  VALUES (
    (SELECT id FROM ecommerce.admins WHERE email = current_setting('request.jwt.claims')::json->>'email'),
    TG_OP,
    TG_TABLE_NAME,
    NEW.id,
    jsonb_build_object('old', row_to_json(OLD), 'new', row_to_json(NEW))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;