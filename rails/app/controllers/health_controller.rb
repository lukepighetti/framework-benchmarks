class HealthController < ApplicationController
    def index
        render plain: 'OK', status: 200
    end
end
