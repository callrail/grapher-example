class CreateCharts < ActiveRecord::Migration[5.1]
  def change
    create_table :charts do |t|
      t.text :content

      t.timestamps
    end
  end
end
