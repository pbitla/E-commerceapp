// User related types
export type Profile = {
  id: string;
  first_name: string | null;
  last_name: string | null;
  phone: string | null;
  email_verified: boolean;
  phone_verified: boolean;
  created_at: string;
  updated_at: string;
};

export type Address = {
  id: string;
  user_id: string;
  address_line: string;
  city: string;
  state: string;
  country: string;
  zip: string;
  created_at: string;
};

// Product related types
export type Product = {
  id: string;
  name: string;
  description: string | null;
  category: string | null;
  price: number;
  discount_percent: number;
  discount_amount: number;
  available_count: number;
  pending_order_count: number;
  image_url: string | null;
  created_at: string;
  updated_at: string;
};

// Order related types
export type Order = {
  id: string;
  user_id: string;
  address_id: string;
  status: 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled';
  total_amount: number;
  coupon_id: string | null;
  shipping_method: string | null;
  tracking_number: string | null;
  created_at: string;
  updated_at: string;
};

export type OrderItem = {
  id: string;
  order_id: string;
  product_id: string;
  quantity: number;
  unit_price: number;
  created_at: string;
};

export type PaymentDetails = {
  id: string;
  order_id: string;
  user_id: string;
  payment_method: string;
  card_type: string | null;
  card_last4: string | null;
  card_expiry: string | null;
  cardholder_name: string | null;
  payment_status: string;
  transaction_id: string;
  amount: number;
  currency: string;
  created_at: string;
  updated_at: string;
};

// Review and favorites
export type Review = {
  id: string;
  product_id: string;
  user_id: string;
  rating: number;
  comment: string | null;
  created_at: string;
};

export type Favorite = {
  id: string;
  user_id: string;
  product_id: string;
  created_at: string;
};

// Coupon and notification types
export type Coupon = {
  id: string;
  code: string;
  discount_type: string;
  discount_value: number;
  expiry: string;
  usage_limit: number | null;
  times_used: number;
  created_at: string;
};

export type Notification = {
  id: string;
  user_id: string;
  type: string;
  message: string;
  status: 'read' | 'unread';
  created_at: string;
};

// Admin related types
export type Admin = {
  id: string;
  name: string;
  email: string;
  role: string;
  status: string;
  last_login: string | null;
  created_at: string;
  updated_at: string;
};

export type AdminPermission = {
  id: string;
  admin_id: string;
  permission: string;
  created_at: string;
};

export type Template = {
  id: string;
  type: 'email' | 'sms';
  name: string;
  content: string;
  created_at: string;
};

export type AuditLog = {
  id: string;
  admin_id: string | null;
  action: string;
  table_name: string;
  record_id: string;
  changes: {
    old: Record<string, any>;
    new: Record<string, any>;
  };
  created_at: string;
};