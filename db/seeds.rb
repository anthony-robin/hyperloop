require 'open-uri'

puts 'Seeding users...'

%i[standard admin super_admin].each do |role|
  avatar = FFaker::Avatar.image(size: '300x300')

  User.create!(
    email: "#{role}@demo.test",
    first_name: FFaker::Name.first_name,
    last_name: FFaker::Name.last_name,
    password: 'password',
    password_confirmation: 'password',
    role: role,
    avatar: {
      io: URI.parse(avatar).open,
      filename: 'avatar'
    }
  )
end
