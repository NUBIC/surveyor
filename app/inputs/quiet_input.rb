class QuietInput < Formtastic::Inputs::HiddenInput
  def to_html
    super
  end
end