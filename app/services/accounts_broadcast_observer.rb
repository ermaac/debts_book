class AccountsBroadcastObserver < BroadcastObserver
  protected

  def prepare_broadcast_updates
    remove_outdated_account_from_dom
    insert_updated_account_into_dom
  end

  def remove_outdated_account_from_dom
    cable_ready['accounts'].remove(selector: account_selector)
  end

  def insert_updated_account_into_dom
    cable_ready['accounts'].insert_adjacent_html(
      selector: '#accounts',
      position: 'afterbegin',
      html: render(object)
    )
  end

  def account_selector
    ".account[data-id=\"#{object.id}\"]"
  end
end
