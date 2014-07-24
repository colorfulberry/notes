#single table sort by time，单表按时间排序语句
def seltf.all_entries
	find(:all, :order => "created_at DESC");
end
