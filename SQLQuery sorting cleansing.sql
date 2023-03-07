SELECT *
From NashvilleHousing




---- Standardise Date format
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

ALTER Table Nashvillehousing
add SaleDateConverted date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)




--- Populate Property Address Data
SELECT *
From NashvilleHousing
---where propertyAddress is Null
Order by ParcelID

SELECT a.parcelid, a.PropertyAddress, b.parcelid, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
on a.ParcelID=b.ParcelID and 
a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
on a.ParcelID=b.ParcelID and 
a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--- Breaking out address into indivdual comlumns 

SELECT PropertyAddress
From NashvilleHousing
---where propertyAddress is Null
---Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , Len(PropertyAddress)) as Address
From NashvilleHousing

ALTER Table Nashvillehousing
add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER Table Nashvillehousing
add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , Len(PropertyAddress))

Select *
From NashvilleHousing

Select OwnerAddress
From NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
, PARSENAME(Replace(OwnerAddress, ',','.'),2)
, PARSENAME(Replace(OwnerAddress, ',','.'),1)
From NashvilleHousing

ALTER Table Nashvillehousing
add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER Table Nashvillehousing
add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER Table Nashvillehousing
add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

Select * 
From NashvilleHousing












--- Change Y and N to Yes and No
Select distinct(soldasvacant), count(soldasvacant)
From NashvilleHousing
group by (SoldAsVacant)
order by 2

Select soldasvacant
, CASE When Soldasvacant ='Y' THEN 'Yes'
       When soldasvacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = CASE When Soldasvacant ='Y' THEN 'Yes'
       When soldasvacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END


--- Remove Duplicates
WITH RowNumCTE AS(
Select *,
   ROW_NUMBER()  OVER (
   PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER by UniqueID
				) row_num

From NashvilleHousing
-- Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

Select * 
From NashvilleHousing


--- Delete unused columns

Select *
from NashvilleHousing

Alter Table nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter Table nashvillehousing
DROP COLUMN Saledate