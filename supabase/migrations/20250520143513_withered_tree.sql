/*
  # Update Profiles Table

  1. Changes
    - Add `is_admin` column to profiles table
    - Add `is_blocked` column to profiles table
*/

ALTER TABLE profiles
ADD COLUMN is_admin boolean DEFAULT false,
ADD COLUMN is_blocked boolean DEFAULT false;