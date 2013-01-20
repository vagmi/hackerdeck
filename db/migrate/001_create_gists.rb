class CreateGists < ActiveRecord::Migration
  def change
    create_table :gists do |t|
      t.string  :gist_number
      t.string  :username
      t.text    :content
      t.text    :processed
      t.string  :etag
      t.timestamps
    end
    add_index :gists, [:gist_number], {:unique=>true}
  end
end
