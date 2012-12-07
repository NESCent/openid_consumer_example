class CreateSectionEdits < ActiveRecord::Migration
  def change
    create_table :section_edits do |t|
	  t.references :admin_user
	  t.references :section
	  t.string "summary" # use quotes for names, and :symbols for references
      t.timestamps
    end
    add_index :section_edits, ['admin_user_id','section_id']
  end
end
