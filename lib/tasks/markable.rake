namespace :markable do
  desc "Delete marks without marker or markable"
  task :delete_orphan_marks => :environment do
    count = Markable::Mark.delete_orphans
    puts "#{count} marks have been deleted."
  end
end