class AddCcAddrToMessages < ActiveRecord::Migration
		def up
			add_column :messages,:cc_addr,:string
		end
		def down
			remove_column :messages,:cc_addr
		end
end
