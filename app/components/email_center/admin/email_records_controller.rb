module EmailCenter
  module Admin
    class EmailRecordsController < ApplicationController
      def destroy
        email = EmailCenter::EmailRecord.find(params[:id])

        email.destroy
        redirect_to '/admin', notice: 'Usunięto'
      end
    end
  end
end
