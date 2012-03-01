Feature: Survey creation
  As a person interested in languages other than English
  I want to write out the survey in the DSL in other languages
  So that I can give it to survey participants that speak other languages
  
  Scenario: Basic questions
    Given I parse
    """
      survey "青少年人际关系问卷", :access_code => "青少年人际关系问卷" do
        section "Basic questions" do
          grid "第二部分：以下列出了一些描述。请您根据自己的实际情况作答。如果“非常不像我”，请选“1”，如果“非常像我”，请选“5”，以此类推。" do
            a "1"
            a "2"
            a "3"
            a "4"
            a "5"
            q "我常常想出新的有趣的点子", :pick => :one
            q "我比同龄的其他孩子更有想象力", :pick => :one
            q "即使一个人独处，我也不会觉得无聊", :pick => :one
          end
        end
      end
    """
    Then there should be 1 surveys with:
      | title         | access_code | display_order |
      | 青少年人际关系问卷     | 青少年人际关系问卷   | 0             |
    And there should be 1 sections with:
      | title           | display_order |
      | Basic questions | 0             |