require 'test_helper'

class MarkTest < ActiveSupport::TestCase

  # Test delete_orphans

  test "delete_orphans does nothing and return 0 if no orphan mark" do
    u1 = get(User)
    f1 = get(Food)
    u1.set_mark :favorite, f1
    assert_no_difference "Markable::Mark.count" do
      assert_equal 0, Markable::Mark.delete_orphans
    end
  end

  test "delete_orphans deletes marks with no markable" do
    u1 = get(User)
    f1, f2 = get(Food, 2)
    u1.set_mark :favorite, [f1, f2]
    u1.set_mark :hated, f1

    # Delete f1 to make two marks orphan
    Food.delete(f1.id)

    # delete_orphans should delete two marks. The remaining one is on f2.
    assert_difference "Markable::Mark.count", -2 do
      assert_equal 2, Markable::Mark.delete_orphans
    end
    assert_equal f2.id, Markable::Mark.first.markable_id
  end

  test "delete_orphans deletes marks with no marker" do
    u1, u2 = get(User, 2)
    f1 = get(Food)
    f1.mark_as :favorite, [u1, u2]

    # Delete u1 to make one mark orphan
    User.delete(u1.id)

    # delete_orphans should delete one mark. The remaining one is from u2.
    assert_difference "Markable::Mark.count", -1 do
      assert_equal 1, Markable::Mark.delete_orphans
    end
    assert_equal u2.id, Markable::Mark.first.marker_id
  end

  test "delete_orphans deletes marks with no marker and no markable" do
    u1 = get(User)
    f1 = get(Food)
    u1.set_mark :favorite, f1

    # Delete u1 and f1 to make the mark orphan
    User.delete(u1.id)
    Food.delete(f1.id)

    # delete_orphans should delete the mark.
    assert_difference "Markable::Mark.count", -1 do
      assert_equal 1, Markable::Mark.delete_orphans
    end
  end
end
