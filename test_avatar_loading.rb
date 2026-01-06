#!/usr/bin/env ruby
# Test script to verify avatar loading fix
# 
# Usage:
#   # In production (via SSH):
#   ssh ubuntu@146.59.44.70
#   docker exec kw-app-web-43b9fa492649f79a72a1ebfc23477f8594db72c8 \
#     bundle exec rails runner test_avatar_loading.rb
#
#   # Or locally:
#   bundle exec rails runner test_avatar_loading.rb

puts "=" * 80
puts "Avatar Loading Test - OpenStack/CarrierWave Bug Verification"
puts "=" * 80
puts

# Test user
test_email = 'dariusz.finster@gmail.com'
puts "🔍 Finding user: #{test_email}"

user = Db::User.find_by(email: test_email)

if user.nil?
  puts "❌ User not found!"
  exit 1
end

puts "✅ User found: ID=#{user.id}, KW_ID=#{user.kw_id}"
puts "   Avatar field: #{user.read_attribute(:avatar).inspect}"
puts

# Test 1: Check if avatar is present
puts "Test 1: Avatar presence check"
puts "-" * 40
begin
  has_avatar = user.avatar.present?
  puts "✅ avatar.present? = #{has_avatar}"
rescue => e
  puts "❌ avatar.present? FAILED: #{e.class} - #{e.message}"
end
puts

# Test 2: Try to get avatar URL multiple times
puts "Test 2: Avatar URL loading (50 attempts)"
puts "-" * 40
successes = 0
failures = 0
errors = []

50.times do |i|
  begin
    url = user.avatar.url
    successes += 1
    print "✓" if i % 10 == 0
  rescue => e
    failures += 1
    error_info = "#{e.class}: #{e.message}"
    errors << error_info unless errors.include?(error_info)
    print "✗"
  end
end

puts
puts
puts "Results:"
puts "  ✅ Successes: #{successes}/50 (#{(successes * 100.0 / 50).round(1)}%)"
puts "  ❌ Failures:  #{failures}/50 (#{(failures * 100.0 / 50).round(1)}%)"

if failures > 0
  puts
  puts "Error types encountered:"
  errors.each do |err|
    puts "  - #{err}"
  end
end
puts

# Test 3: Test file size method (where the bug occurs)
puts "Test 3: File size check (source of 'zero?' bug)"
puts "-" * 40
begin
  if user.avatar.present?
    file = user.avatar.file
    puts "File object: #{file.class}"
    
    # This is where the bug happens
    size = file.size
    puts "✅ file.size = #{size} bytes"
    
    empty = file.empty?
    puts "✅ file.empty? = #{empty}"
  else
    puts "⚠️  No avatar file to test"
  end
rescue => e
  puts "❌ File size check FAILED: #{e.class} - #{e.message}"
  puts "   This is the bug we're fixing!"
  puts
  puts "Backtrace (first 10 lines):"
  e.backtrace.first(10).each { |line| puts "   #{line}" }
end
puts

# Test 4: Test with helper method (if available)
puts "Test 4: Safe avatar helper (50 attempts)"
puts "-" * 40

# Load helper if in Rails context
if defined?(AvatarHelper)
  include AvatarHelper
  
  helper_successes = 0
  helper_failures = 0
  
  50.times do |i|
    begin
      url = safe_avatar_url(user)
      helper_successes += 1
      print "✓" if i % 10 == 0
    rescue => e
      helper_failures += 1
      print "✗"
    end
  end
  
  puts
  puts
  puts "Helper Results:"
  puts "  ✅ Successes: #{helper_successes}/50 (#{(helper_successes * 100.0 / 50).round(1)}%)"
  puts "  ❌ Failures:  #{helper_failures}/50 (#{(helper_failures * 100.0 / 50).round(1)}%)"
else
  puts "⚠️  AvatarHelper not available (may not be loaded in runner context)"
end
puts

# Test 5: Check CarrierWave configuration
puts "Test 5: CarrierWave configuration check"
puts "-" * 40
if defined?(CarrierWave) && CarrierWave.configure
  config = CarrierWave::Uploader::Base.fog_credentials rescue nil
  
  if config
    puts "Fog provider: #{config[:provider]}"
    puts "OpenStack region: #{config[:openstack_region]}"
    puts "Connection options:"
    if config[:connection_options]
      puts "  - connect_timeout: #{config[:connection_options][:connect_timeout]}s"
      puts "  - read_timeout: #{config[:connection_options][:read_timeout]}s"
      puts "  - write_timeout: #{config[:connection_options][:write_timeout]}s"
      
      if config[:connection_options][:read_timeout] && config[:connection_options][:read_timeout] < 10
        puts "  ⚠️  WARNING: Timeouts are very aggressive (< 10s)"
        puts "     Consider increasing to 30s to avoid random failures"
      end
    end
  else
    puts "⚠️  Fog credentials not configured (may be using file storage)"
  end
else
  puts "⚠️  CarrierWave not configured"
end
puts

# Summary
puts "=" * 80
puts "SUMMARY"
puts "=" * 80

if failures == 0
  puts "✅ All tests passed! Avatar loading is working correctly."
  puts "   No 'zero?' errors detected."
else
  puts "⚠️  Avatar loading is INTERMITTENT (#{failures}/50 failures)"
  puts "   This indicates the OpenStack timeout bug is still present."
  puts
  puts "Recommended fixes:"
  puts "  1. Apply carrierwave_fog_fix.rb initializer"
  puts "  2. Increase timeouts to 30 seconds in carrierwave.rb"
  puts "  3. Use safe_avatar_url helper in views"
end
puts "=" * 80