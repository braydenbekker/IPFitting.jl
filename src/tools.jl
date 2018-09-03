
module Tools

using ProgressMeter, Base.Threads

function tfor(f, rg; verbose=true, msg="tfor", costs = ones(Int, length(rg)))
   p = Progress(sum(costs))
   p_ctr = 0
   if nthreads() == 1
      verbose && println("$msg in serial")
      dt = verbose ? 1.0 : Inf
      tic()
      for (i, n) in enumerate(rg)
         f(n)
         p_ctr += costs[i]
         ProgressMeter.update!(p, p_ctr)
      end
      verbose && toc()
   else
      if verbose
         println("$msg with $(nthreads()) threads")
         p_lock = SpinLock()
      end
      tic()
      @threads for n in rg
         f(n)
         if verbose
            lock(p_lock)
            p_ctr += costs[i]
            ProgressMeter.update!(p, p_ctr)
            unlock(p_lock)
         end
      end
      verbose && toc()
   end
   return nothing
end

decode(D::Dict) = convert(Val(Symbol(D["__id__"])), D)



function analyse_include_exclude(set, include, exclude)
   if include != nothing && exclude != nothing
      error("only one of `include`, `exclude` may be different from `nothing`")
   end
   if include != nothing
      if !issubset(include, set)
         error("`include` can only contain elements of `set`")
      end
      # do nothing - just keep `include` as is to return
   elseif exclude != nothing
      if !issubset(exclude, set)
         error("`exclude` can only contain config types that are in `set`")
      end
      include = setdiff(set, exclude)
   else
      # both are nothing => keep all config_types
      include = set
   end
   return include
end



end
