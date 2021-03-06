require 'test_helper'

class AgeVisualizationTest < Test::Unit::TestCase
  AVR = Kii::Diff::AgeVisualization::Revision
  
  def setup
    @one_day_ago = 1.day.ago
    @two_days_ago = 2.days.ago
    @now = Time.now
    @visualizer = Kii::Diff::AgeVisualization.new
  end
  
  def test_basic_object_tree
    expected = [
      AVR.new("This is", @one_day_ago),
      AVR.new(" some pretty old", @two_days_ago),
      AVR.new(" text.", @now)
    ]

    revisions = [
      AVR.new("That was some pretty old milk.", @two_days_ago),
      AVR.new("This is some pretty old milk.", @one_day_ago),
      AVR.new("This is some pretty old text.", @now)
    ]
    
    @visualizer.revisions = revisions
    @visualizer.compute
    assert_equal expected, @visualizer.nodes
  end
  
  def test_newlines
    revisions = [
      AVR.new("Hello World!", @two_days_ago),
      AVR.new("Hello World!\nThis rocks.", @now)
    ]
    
    expected = [
      AVR.new("Hello World!", @two_days_ago),
      AVR.new("\nThis rocks.", @now)
    ]
    
    @visualizer.revisions = revisions
    @visualizer.compute
    assert_equal expected, @visualizer.nodes
  end
  
  def test_one_revision
    @visualizer.revisions = [AVR.new("Hello World!", @two_days_ago)]
    @visualizer.compute
    node = @visualizer.nodes[0]
    assert_equal 0, node.age
    assert_equal @two_days_ago, node.timestamp
  end
end