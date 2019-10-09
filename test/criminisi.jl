@testset "Crimisini" begin
  if visualtests
    plot_blobs(fname) = plot_criminisi_on_array(fname, blobs, (50:150,50:150), (11,11))
    refimg = joinpath(datadir,"Blobs.png")
    @test test_images(VisualTest(plot_blobs, refimg), popup=!istravis) |> success

    plot_lighthouse(fname) = plot_criminisi_on_array(fname, lighthouse, (50:350,300:400), (30,30))
    refimg = joinpath(datadir,"LightHouse.png")
    @test test_images(VisualTest(plot_lighthouse, refimg), popup=!istravis) |> success
  end
end
