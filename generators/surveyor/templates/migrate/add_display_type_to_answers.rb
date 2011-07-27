class AddDisplayTypeToAnswers < ActiveRecord::Migration
  def self.up
    add_column :answers, :display_type, :string
    set_display_type_to_hidden
    remove_column :answers, :hide_label
  end

  def self.down
    add_column :answers, :hide_label, :boolean
    set_hide_label_to_true
    remove_column :answers, :display_type
  end

  private

  def self.set_display_type_to_hidden
    if Answer
      Answer.all.each{|a| a.update_attributes(:display_type => "hidden_label") if a.hide_label == true}
    end
  end

  def self.set_hide_label_to_true
    if Answer
      Answer.all.each{|a| a.update_attributes(:hide_label => true) if a.display_type == "hidden_label"}
    end
  end

end