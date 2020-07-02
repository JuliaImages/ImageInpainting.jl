@testset "Crimisini" begin
    refdir = joinpath(datadir, "criminisi")

    # Diagonal
    img  = [i + j > 10 ? 0.1 : 0.2 for i in 1:10, j in 1:10]
    mask = [1.2cos(i) + i > j for i in 1:10, j in 1:10]
    out  = inpaint(img, mask, Criminisi(5,5))
    @test_reference joinpath(refdir, "Diagonal.txt") out

    # Cross
    img = zeros(20,20) .+ 0.5
    for i in 1:20
        img[i,i] = 1.0
        img[i,20-i+1] = 1.0
    end
    mask = falses(size(img))
    mask[8:12,6:16] .= true
    out = inpaint(img, mask, Criminisi(9,9))
    @test_reference joinpath(refdir, "Cross.txt") out

    # Blobs
    img  = Float64.(Gray.(testimage("blobs")))
    mask = falses(size(img))
    mask[50:150,50:150] .= true
    out = inpaint(img, mask, Criminisi(11,11))
    @test_reference joinpath(refdir, "Blobs.png") Gray.(out)

    # LightHouse
    img  = Float64.(Gray.(testimage("lighthouse")))
    mask = falses(size(img))
    mask[50:350,300:400] .= true
    out = inpaint(img, mask, Criminisi(30,30))
    @test_reference joinpath(refdir, "LightHouse.png") Gray.(out)
end
