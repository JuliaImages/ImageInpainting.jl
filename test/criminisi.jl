@testset "Crimisini" begin
  if visualtests
    img  = [i + j > 10 ? 0.1 : 0.2 for i in 1:10, j in 1:10]
    mask = [1.2cos(i) + i > j for i in 1:10, j in 1:10]
    out  = inpaint(img, mask, Criminisi(5,5))
    @plottest plot_before_after(img,mask,out) joinpath(datadir,"Diagonal.png") !istravis

    img = zeros(50,50) .+ 0.5
    for i in 1:50
      img[i,i] = 1.0
      img[i,50-i+1] = 1.0
    end
    mask = falses(size(img))
    mask[20:30,15:40] .= true
    out = inpaint(img, mask, Criminisi(9,9))
    @plottest plot_before_after(img,mask,out) joinpath(datadir,"Cross.png") !istravis

    # blobs = testimage("blobs")
    # plot_blobs(fname) = plot_criminisi_on_array(fname, blobs, (50:150,50:150), (11,11))
    # refimg = joinpath(datadir,"Blobs.png")
    # @test test_images(VisualTest(plot_blobs, refimg), popup=!istravis) |> success

    # lighthouse = testimage("lighthouse")
    # plot_lighthouse(fname) = plot_criminisi_on_array(fname, lighthouse, (50:350,300:400), (30,30))
    # refimg = joinpath(datadir,"LightHouse.png")
    # @test test_images(VisualTest(plot_lighthouse, refimg), popup=!istravis) |> success
  end
end
