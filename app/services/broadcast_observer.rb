class BroadcastObserver
  include CableReady::Broadcaster

  attr_reader :object

  def initialize(object)
    @object = object
  end

  def notify
    return if Rails.env.test?

    prepare_broadcast_updates
    broadcast
  end

  protected

  def prepare_broadcast_updates
    raise NotImplementedError
  end

  delegate :broadcast, to: :cable_ready
  delegate :render, to: :ApplicationController
end
