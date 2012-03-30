namespace :mailr do

	desc "Removes all users data from db"
    task :remove_all_data => :environment do
        users = User.all
        puts "Number of users in db: #{users.size}"
        puts "Deleting data....."
        User.destroy_all
        puts "Done"
	end

	desc "Deletes users data (messages,folders,contacts)"
	task :remove_users_data => :environment do
        users = User.all
        users.each do |u|
            puts "Removing folders & messages for user #{u.email}"
            u.folders.destroy_all
            puts "Removing contacts for user #{u.email}"
            u.contacts.destroy_all
        end
	end

end
