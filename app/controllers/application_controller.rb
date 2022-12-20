class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    rescue_from Exception, with: :handle_exception
    def handle_exception(_e)
      raise _e.message.gsub(/"/, '')
    end
end