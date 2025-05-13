module ApplicationHelper
  include ProductsHelper

  def lato_invitation_actions(invitation)
    content_tag(:div, class: 'btn-group btn-group-sm') do
      unless invitation.accepted?
        concat link_to('Send', main_app.invitations_send_invite_action_path(id: invitation.id), class: 'btn btn-info', data: { turbo_method: :patch })
        concat link_to('Delete', main_app.invitations_destroy_invite_action_path(id: invitation.id), class: 'btn btn-danger', data: { turbo_method: :delete })
      end
    end
  end

  def lato_index_dynamic_label(params)
    'Custom column'
  end

  def lato_index_dynamic_value(params)
    'Custom value'
  end
end
