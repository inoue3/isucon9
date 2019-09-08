use `isucari`;

ALTER TABLE items ADD INDEX index_items_on_created_at(created_at);
ALTER TABLE items ADD INDEX index_items_on_seller_id(seller_id);
ALTER TABLE items ADD INDEX index_items_on_buyer_id(buyer_id);