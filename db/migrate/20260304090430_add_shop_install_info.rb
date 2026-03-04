class AddShopInstallInfo < ActiveRecord::Migration[8.1]
  def change
    add_column :shops, :installed, :boolean, default: true
    add_column :shops, :uninstalled_at, :datetime
  end
end
