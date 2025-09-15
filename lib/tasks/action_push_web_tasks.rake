namespace :action_push_web do
  desc "Generates a VAPID key"
  task :generate_vapid_key do
    vapid_key = WebPush.generate_key
    puts "PRIVATE KEY : #{vapid_key.private_key}"
    puts "PUBLIC KEY  : #{vapid_key.public_key}"
  end
end
