require 'test_helper'

class RdiffTest < ActiveSupport::TestCase
  Core = Kii::Diff::Rdiff::Core
  LCS = Kii::Diff::Rdiff::LCS
  
  S1 = "now is      the time for all good#{
      } men to come to the aid of their"
  S2 = "is now the right time for all #{
        }to come to their senses?"

  # run a given test both with and without token mapping,
  # ..and for both the Core and optimizing wrapper LCS
  # It only takes an expected diff as the matrix that is produced
  # ..will vary as the optimizing wrapper evolves

  def lcsrun form, symbols1, symbols2, answer
    [true, false].product([Core, LCS]).each do |x|
      useHash, wrapperClass = x
      assert_equal (wrapperClass.send form, symbols1, symbols2, useHash
                   ).diff, answer, "lcsrun #{wrapperClass.inspect
                                    } #{useHash}"
    end
  end

  def test_space_preserving_split
    expected =[["+ ", "is "],
               ["  ", "now "],
               ["- ", "is      "],
               ["  ", "the "],
               ["+ ", "right "],
               ["  ", "time "],
               ["  ", "for "],
               ["  ", "all "],
               ["- ", "good "],
               ["- ", "men "],
               ["  ", "to "],
               ["  ", "come "],
               ["  ", "to "],
               ["- ", "the "],
               ["- ", "aid "],
               ["- ", "of "],
               ["- ", "their"],
               ["+ ", "their "],
               ["+ ", "senses?"]]

    lcsrun :WordsSaveWS, S1, S2, expected
  end
  def test_space_discarding_split
    expected =[[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
               [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
               [0, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
               [0, 1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3],
               [0, 1, 1, 2, 2, 3, 4, 4, 4, 4, 4, 4, 4],
               [0, 1, 1, 2, 2, 3, 4, 5, 5, 5, 5, 5, 5],
               [0, 1, 1, 2, 2, 3, 4, 5, 5, 5, 5, 5, 5],
               [0, 1, 1, 2, 2, 3, 4, 5, 5, 5, 5, 5, 5],
               [0, 1, 1, 2, 2, 3, 4, 5, 6, 6, 6, 6, 6],
               [0, 1, 1, 2, 2, 3, 4, 5, 6, 7, 7, 7, 7],
               [0, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 8, 8],
               [0, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 8, 8],
               [0, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 8, 8],
               [0, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 8, 8],
               [0, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 9]]

    assert_equal expected, (Core.WordsSqueezeWS S1, S2, true).c
    assert_equal expected, (Core.WordsSqueezeWS S1, S2, false).c
  end
  def test_matrix
    expected = [ [0, 0, 0, 0, 0, 0, 0, 0],
                 [0, 0, 0, 0, 0, 0, 1, 1],
                 [0, 1, 1, 1, 1, 1, 1, 1],
                 [0, 1, 1, 2, 2, 2, 2, 2],
                 [0, 1, 1, 2, 2, 2, 2, 2],
                 [0, 1, 1, 2, 3, 3, 3, 3],
                 [0, 1, 1, 2, 3, 3, 3, 4],
                 [0, 1, 2, 2, 3, 3, 3, 4] ]

    assert_equal expected,
      (Core.new 'XMJYAUZ'.chars, 'MZJAWXU'.chars, false).c
    assert_equal expected,
      (Core.new 'XMJYAUZ'.chars, 'MZJAWXU'.chars, true).c
  end
  def test_diff
    expected = [ ["- ", "X"],
                 ["  ", "M"],
                 ["+ ", "Z"],
                 ["  ", "J"],
                 ["- ", "Y"],
                 ["  ", "A"],
                 ["+ ", "W"],
                 ["+ ", "X"],
                 ["  ", "U"],
                 ["- ", "Z"] ]

    lcsrun :Core, 'XMJYAUZ'.chars, 'MZJAWXU'.chars, expected
  end
  def test_diff_middle
    expected = [
                 ["  ", "S"],
                 ["  ", "A"],
                 ["  ", "M"],
                 ["  ", "E"],
                 ["- ", "X"],
                 ["  ", "M"],
                 ["+ ", "Z"],
                 ["  ", "J"],
                 ["- ", "Y"],
                 ["  ", "A"],
                 ["+ ", "W"],
                 ["+ ", "X"],
                 ["  ", "U"],
                 ["- ", "Z"],
                 ["  ", "S"],
                 ["  ", "A"],
                 ["  ", "M"],
                 ["  ", "E"]]

    lcsrun :Core, 'SAMEXMJYAUZSAME'.chars, 'SAMEMZJAWXUSAME'.chars, expected
  end
  def test_diff_middle_first_last
    s1 = 'ASAMEXMJYAUZSAMEZ'.chars
    s2 = 'BSAMEMZJAWXUSAMEY'.chars
    expected = [
                 ["- ", "A"],
                 ["+ ", "B"],
                 ["  ", "S"],
                 ["  ", "A"],
                 ["  ", "M"],
                 ["  ", "E"],
                 ["- ", "X"],
                 ["  ", "M"],
                 ["+ ", "Z"],
                 ["  ", "J"],
                 ["- ", "Y"],
                 ["  ", "A"],
                 ["+ ", "W"],
                 ["+ ", "X"],
                 ["  ", "U"],
                 ["- ", "Z"],
                 ["  ", "S"],
                 ["  ", "A"],
                 ["  ", "M"],
                 ["  ", "E"],
                 ["- ", "Z"],
                 ["+ ", "Y"]]
    lcsrun :Core, s1, s2, expected
  end
  def test_null_vs_string
    s1 = ''.chars
    s2 = 'BSAMEMZJAWXUSAMEY'.chars
    expected = [
                  ['+ ', 'B'],
                  ['+ ', 'S'],
                  ['+ ', 'A'],
                  ['+ ', 'M'],
                  ['+ ', 'E'],
                  ['+ ', 'M'],
                  ['+ ', 'Z'],
                  ['+ ', 'J'],
                  ['+ ', 'A'],
                  ['+ ', 'W'],
                  ['+ ', 'X'],
                  ['+ ', 'U'],
                  ['+ ', 'S'],
                  ['+ ', 'A'],
                  ['+ ', 'M'],
                  ['+ ', 'E'],
                  ['+ ', 'Y']
                 ]
    lcsrun :Core, s1, s2, expected
  end
end
