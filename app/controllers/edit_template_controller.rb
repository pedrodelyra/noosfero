class EditTemplateController < ApplicationController

  design_editor :holder => 'virtual_community', :autosave => true, :block_types => :block_types
  
  def block_types
    { 
      'ListBlock' => _("List Block"), 
      'LinkBlock' => _("Link Block"),
      'RecentDocumentsBlock' => _('Recent documents'),
      'Design::MainBlock' => _('Main content block'),
    }
  end

  def index
    redirect_to :action => 'design_editor'
  end

end
