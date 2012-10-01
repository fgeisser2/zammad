module ExtraCollection
  def add(collections)

    # all ticket stuff
    collections['TicketStateType']     = Ticket::StateType.all
    collections['TicketState']         = Ticket::State.all
    collections['TicketPriority']      = Ticket::Priority.all
    collections['TicketArticleType']   = Ticket::Article::Type.all
    collections['TicketArticleSender'] = Ticket::Article::Sender.all

    # all signatures
    collections['Signature']           = Signature.all

    # all email addresses
    collections['EmailAddress']        = EmailAddress.all

  end
  module_function :add
end