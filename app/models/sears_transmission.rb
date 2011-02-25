=begin
+----------------+------------+------+-----+---------+----------------+
| Field          | Type       | Null | Key | Default | Extra          |
+----------------+------------+------+-----+---------+----------------+
| id             | int(11)    | NO   | PRI | NULL    | auto_increment |
| sent_at        | datetime   | YES  |     | NULL    |                |
| variations     | text       | YES  |     | NULL    |                |
| description    | text       | YES  |     | NULL    |                |
| sync_inventory | tinyint(1) | YES  |     | NULL    |                |
| created_at     | datetime   | YES  |     | NULL    |                |
| updated_at     | datetime   | YES  |     | NULL    |                |
+----------------+------------+------+-----+---------+----------------+
=end

class SearsTransmission < ActiveRecord::Base
  
  validates_presence_of :sent_at, :variations
  
  def variation_count
    return 0 if self.variations.blank?
    self.variations.split(",").size
  end #end method variation_count
  
end
