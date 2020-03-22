# frozen_string_literal: true

class ApplicationController < Jets::Controller::Base
  def head(status)
    render json: {}, status: status
  end
end
