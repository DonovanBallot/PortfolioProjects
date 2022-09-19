
-- Cleaning Data in SQL Queries

Select *
From PortfolioProject.dbo.NashvilleHousing



-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER Table PortfolioProject..NashvilleHousing
Add SaleDateConverted Date

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER Table PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

ALTER Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER Table PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER Table PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END



-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
-- order by ParcelID
)
Select *
From RowNumCTE
Order by PropertyAddress



-- Delete Unused Column

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate