module MemoryAllocation
	def kb_to_mb(kb)
		kb.to_i / 1024.0 
	end
	def get_available_memory(node)
		kb_to_mb node['memory']['total'].chomp('kB')
	end
	def get_memory_remaining(total, memory)
		memory_remaining = total
		memory.each do |key, mem_used|
			memory_remaining -= mem_used
		end
		memory_remaining
	end
end