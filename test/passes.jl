using Test
using ParametricInversion
using IRTools

function bubblesort(arr)
  n = length(arr)
  for i=1:n, j=1:n-i
      if (arr[j] > arr[j+1])
          arr[j], arr[j+1] = arr[j+1], arr[j]
      end
  end
  arr
end

function test()
  ir = IRTools.explicitbranch!(@code_ir bubblesort(rand(5)))
  ParametricInversion.passvars!(ir)
end
