Before do
  FileUtils.mkdir_p(DESTINATION_ROOT)
end

After do
  FileUtils.rm_rf(DESTINATION_ROOT)
end

Given /^the jekyll_and_hyde gem installed$/ do
end

When /^I run the "jh ([^"]*)" command inside folder "([^"]*)"$/ do |parameters, folder|
  parameters = parameters.split.map(&:strip)
  task = parameters.shift
  args, opts = Thor::Options.split(parameters)

  @task = JekyllAndHyde::Util.find_task_class(task).new(args, opts)
  @task.destination_root = File.join(DESTINATION_ROOT, folder)
  @task.invoke(JekyllAndHyde.to_namespace(task))
end

Then /^I should have a folder named "([^"]*)" created$/ do |folder_name|
  File.should be_directory(File.join(DESTINATION_ROOT, folder_name))
end

And /^I should have template files\/folders "([^"]*)" inside folder "([^"]*)"$/ do |template_files, folder_name|
  template_files.split(',').map(&:strip).each do |template_file|
    File.should be_exist(File.join(DESTINATION_ROOT, folder_name, template_file))
  end
end

Then /^I should have a git branch named "([^"]*)" created in folder "([^"]*)"$/ do |branch_name, folder_name|
  output = IO.popen("cd #{File.join(DESTINATION_ROOT, folder_name)} && git branch")
  output.readlines.first.include?(branch_name)
end

Then /^I should have a file named "([^"]*)" prefixed with timestamp created in posts folder "([^"]*)"$/ do |file_name, folder_name|
  posts_folder = Dir[File.join(DESTINATION_ROOT, folder_name, "**", "*.*")]
  posts_folder.should have(1).file
  post_file_name = posts_folder.first.scan(/\d\d\d\d-\d\d-\d\d-\d\d-\d\d-\d\d-(.*)/).flatten.first
  post_file_name.should == file_name
end