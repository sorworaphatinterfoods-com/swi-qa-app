-- Migration 0027: add production method (กรรมวิธีการผลิต) to the FDA product register.
-- Thai FDA registers the food category (e.g. "อาหารแปรรูปบางชนิด") and the production
-- method (e.g. "แช่เยือกแข็ง" / frozen) as separate attributes on the food serial number.
-- Safe: ADD COLUMN is additive.
-- Run: wrangler d1 execute qa-factory-db --file=migrations/0027_reg_production_method.sql --remote

ALTER TABLE reg_products ADD COLUMN productionMethod TEXT;
