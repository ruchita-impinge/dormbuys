class SetDefaultCartUserProfileId < ActiveRecord::Migration
  def self.up
    change_column_default :carts, :user_profile_type_id, 1
    change_column_default :carts, :payment_provider_id, 1
    execute "UPDATE carts set user_profile_type_id = 1, payment_provider_id = 1;"
  end

  def self.down
    change_column_default :carts, :payment_provider_id, nil
    change_column_default :carts, :user_profile_type_id, nil
  end
end