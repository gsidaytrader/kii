class IpsController < ApplicationController
  def show
    @ip = params[:id]
    @revisions = Revision.all(:conditions => {:user_id => nil, :remote_ip => @ip}, :include => [:page], :limit => 20)
    @created_pages = Page.by_ip(@ip).all(:limit => 20)
    @discussions = Discussion.grouped_by_entries.by_ip(@ip).with_page.all(:limit => 20)
  end
end
