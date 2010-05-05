class PopulateLntCategories < ActiveRecord::Migration
  def self.up
    ThirdPartyCategory.create(:name => "Allergy Relief Bedding", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Bedding Accessories", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Bed in a Bag", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Blankets & Throws", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Comforters", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Dorm Bedding", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Down Comforters", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Duvet Covers", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Futon Covers", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Kid's Bedding", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Mattress Pads", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Mattress Toppers", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Pillows", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Sheets", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Team Bedding", :owner => "Linens-N-Things", :parent => "Bedding")
    ThirdPartyCategory.create(:name => "Teen Bedding", :owner => "Linens-N-Things", :parent => "Bedding")

    ThirdPartyCategory.create(:name => "Bath Accessories", :owner => "Linens-N-Things", :parent => "Bathroom")
    ThirdPartyCategory.create(:name => "Bath Towels", :owner => "Linens-N-Things", :parent => "Bathroom")
    ThirdPartyCategory.create(:name => "Laundry/Cleaning", :owner => "Linens-N-Things", :parent => "Bathroom")
    ThirdPartyCategory.create(:name => "Personal Care", :owner => "Linens-N-Things", :parent => "Bathroom")
    ThirdPartyCategory.create(:name => "Robes", :owner => "Linens-N-Things", :parent => "Bathroom")
    ThirdPartyCategory.create(:name => "Shower Curtains", :owner => "Linens-N-Things", :parent => "Bathroom")
    ThirdPartyCategory.create(:name => "Shower Caddy", :owner => "Linens-N-Things", :parent => "Bathroom")

    ThirdPartyCategory.create(:name => "Bike Racks", :owner => "Linens-N-Things", :parent => "Storage & Organization")
    ThirdPartyCategory.create(:name => "Bins", :owner => "Linens-N-Things", :parent => "Storage & Organization")
    ThirdPartyCategory.create(:name => "Closet Storage", :owner => "Linens-N-Things", :parent => "Storage & Organization")
    ThirdPartyCategory.create(:name => "Food Storage", :owner => "Linens-N-Things", :parent => "Storage & Organization")
    ThirdPartyCategory.create(:name => "Hangers", :owner => "Linens-N-Things", :parent => "Storage & Organization")
    ThirdPartyCategory.create(:name => "Locker Accessories", :owner => "Linens-N-Things", :parent => "Storage & Organization")
    ThirdPartyCategory.create(:name => "Locker Shelves", :owner => "Linens-N-Things", :parent => "Storage & Organization")
    ThirdPartyCategory.create(:name => "Luggage", :owner => "Linens-N-Things", :parent => "Storage & Organization")
    ThirdPartyCategory.create(:name => "Over the Door", :owner => "Linens-N-Things", :parent => "Storage & Organization")
    ThirdPartyCategory.create(:name => "Storage Boxes", :owner => "Linens-N-Things", :parent => "Storage & Organization")
    ThirdPartyCategory.create(:name => "Shoe Racks", :owner => "Linens-N-Things", :parent => "Storage & Organization")

    ThirdPartyCategory.create(:name => "Alarm Clocks/Clocks", :owner => "Linens-N-Things", :parent => "Furniture")
    ThirdPartyCategory.create(:name => "Bookcases/Shelving", :owner => "Linens-N-Things", :parent => "Furniture")
    ThirdPartyCategory.create(:name => "Decorative Accessories", :owner => "Linens-N-Things", :parent => "Furniture")
    ThirdPartyCategory.create(:name => "Room Furnishings", :owner => "Linens-N-Things", :parent => "Furniture")
    ThirdPartyCategory.create(:name => "Slipcovers", :owner => "Linens-N-Things", :parent => "Furniture")
    ThirdPartyCategory.create(:name => "Team Stuff", :owner => "Linens-N-Things", :parent => "Furniture")

    ThirdPartyCategory.create(:name => "Bakeware/Cookware", :owner => "Linens-N-Things", :parent => "Kitchen")
    ThirdPartyCategory.create(:name => "Dinnerware/Glassware", :owner => "Linens-N-Things", :parent => "Kitchen")
    ThirdPartyCategory.create(:name => "Food Storage", :owner => "Linens-N-Things", :parent => "Kitchen")
    ThirdPartyCategory.create(:name => "Kitchen Electrics", :owner => "Linens-N-Things", :parent => "Kitchen")
    ThirdPartyCategory.create(:name => "Kitchen Utensils", :owner => "Linens-N-Things", :parent => "Kitchen")
    ThirdPartyCategory.create(:name => "Water Filtration", :owner => "Linens-N-Things", :parent => "Kitchen")

    ThirdPartyCategory.create(:name => "Alarm Clocks/Clocks", :owner => "Linens-N-Things", :parent => "Electric Accessories")
    ThirdPartyCategory.create(:name => "Fans/Heaters", :owner => "Linens-N-Things", :parent => "Electric Accessories")
    ThirdPartyCategory.create(:name => "Irons & Boards", :owner => "Linens-N-Things", :parent => "Electric Accessories")
    ThirdPartyCategory.create(:name => "Steamers", :owner => "Linens-N-Things", :parent => "Electric Accessories")
    ThirdPartyCategory.create(:name => "Sweepers", :owner => "Linens-N-Things", :parent => "Electric Accessories")
    ThirdPartyCategory.create(:name => "Vacuums", :owner => "Linens-N-Things", :parent => "Electric Accessories")

    ThirdPartyCategory.create(:name => "Backpacks", :owner => "Linens-N-Things", :parent => "School Supplies")
    ThirdPartyCategory.create(:name => "Coolers", :owner => "Linens-N-Things", :parent => "School Supplies")
    ThirdPartyCategory.create(:name => "Lunchboxes", :owner => "Linens-N-Things", :parent => "School Supplies")
    ThirdPartyCategory.create(:name => "Rolling Backpacks", :owner => "Linens-N-Things", :parent => "School Supplies")

    ThirdPartyCategory.create(:name => "Fitness Items", :owner => "Linens-N-Things", :parent => "Fitness")
  end

  def self.down
    ThirdPartyCategory.find_all_by_owner("Linens-N-Things").each do |c|
      c.destroy
    end
  end
end
