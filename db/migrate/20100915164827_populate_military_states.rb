class PopulateMilitaryStates < ActiveRecord::Migration
  def self.up
    State.create(:id => 65, :full_name => 'US Military AP', :abbreviation => 'AP')
    State.create(:id => 66, :full_name => 'US Military AE', :abbreviation => 'AE')
    State.create(:id => 67, :full_name => 'US Military AA', :abbreviation => 'AA')
  end

  def self.down
  end
end
