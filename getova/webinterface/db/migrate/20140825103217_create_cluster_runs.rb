class CreateClusterRuns < ActiveRecord::Migration
  def change
    create_table :cluster_runs do |t|

      t.timestamps
    end
  end
end
