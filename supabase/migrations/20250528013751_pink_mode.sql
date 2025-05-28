/*
  # Create E-commerce Schema

  1. Changes
    - Create new 'ecommerce' schema
    - Create new tables in 'ecommerce' schema:
      - products
      - orders
      - order_items
      - reviews
      - favorites
    
  2. Security
    - Enable RLS on all tables
    - Set up appropriate policies for each table
*/

-- Create new schema
CREATE SCHEMA ecommerce;

-- Products table
CREATE TABLE ecommerce.products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  category text,
  price numeric NOT NULL CHECK (price >= 0),
  discount_percent numeric DEFAULT 0 CHECK (discount_percent >= 0 AND discount_percent <= 100),
  discount_amount numeric DEFAULT 0 CHECK (discount_amount >= 0),
  available_count integer DEFAULT 0 CHECK (available_count >= 0),
  pending_order_count integer DEFAULT 0 CHECK (pending_order_count >= 0),
  image_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Orders table
CREATE TABLE ecommerce.orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id),
  status text NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
  total_amount numeric NOT NULL CHECK (total_amount >= 0),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Order items table
CREATE TABLE ecommerce.order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES ecommerce.orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES ecommerce.products(id) ON DELETE SET NULL,
  quantity integer NOT NULL CHECK (quantity > 0),
  unit_price numeric NOT NULL CHECK (unit_price >= 0),
  created_at timestamptz DEFAULT now()
);

-- Reviews table
CREATE TABLE ecommerce.reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES ecommerce.products(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment text,
  created_at timestamptz DEFAULT now()
);

-- Favorites table
CREATE TABLE ecommerce.favorites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id uuid REFERENCES ecommerce.products(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, product_id)
);

-- Enable Row Level Security
ALTER TABLE ecommerce.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE ecommerce.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE ecommerce.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE ecommerce.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE ecommerce.favorites ENABLE ROW LEVEL SECURITY;

-- Products policies
CREATE POLICY "Products are viewable by everyone"
  ON ecommerce.products FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Only admins can insert products"
  ON ecommerce.products FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT is_admin FROM public.profiles WHERE id = auth.uid()));

CREATE POLICY "Only admins can update products"
  ON ecommerce.products FOR UPDATE
  TO authenticated
  USING ((SELECT is_admin FROM public.profiles WHERE id = auth.uid()));

-- Orders policies
CREATE POLICY "Users can view own orders"
  ON ecommerce.orders FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own orders"
  ON ecommerce.orders FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Order items policies
CREATE POLICY "Users can view own order items"
  ON ecommerce.order_items FOR SELECT
  TO authenticated
  USING (auth.uid() = (SELECT user_id FROM ecommerce.orders WHERE id = order_id));

CREATE POLICY "Users can insert own order items"
  ON ecommerce.order_items FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = (SELECT user_id FROM ecommerce.orders WHERE id = order_id));

-- Reviews policies
CREATE POLICY "Reviews are viewable by everyone"
  ON ecommerce.reviews FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can create reviews"
  ON ecommerce.reviews FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reviews"
  ON ecommerce.reviews FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Favorites policies
CREATE POLICY "Users can view own favorites"
  ON ecommerce.favorites FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own favorites"
  ON ecommerce.favorites FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);