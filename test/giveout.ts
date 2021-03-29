import { Client, Provider, ProviderRegistry, Result } from "@blockstack/clarity";
import { assert, expect } from "chai";

describe("giveout contract test suite", () => {
    let giveoutClient: Client;
    let provider: Provider;
    before(async () => {
        provider = await ProviderRegistry.createProvider();
        giveoutClient = new Client("SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB.giveout", "giveout", provider);
    });

    it("should have valid syntax", async () => {
        await giveoutClient.checkContract();
    });

    describe("deploying an instance of the contract", () => {
        const getGiveawayNonce = async () => {
            const query = giveoutClient.createQuery({ method: { name: "get-giveaway-id-nonce", args: [] } });
            const receipt = await giveoutClient.submitQuery(query);
            if (receipt.success && receipt.result) {
                return parseInt(receipt.result.slice(1), 10);
            }
        }

        const execMethod = async (method: string) => {
            const tx = giveoutClient.createTransaction({
                method: {
                    name: method,
                    args: [],
                },
            });
            await tx.sign("ST1B6H4JPKP37CHBWW5R8KWV4PPZQBXM81YBBB71C");
            const receipt = await giveoutClient.submitTransaction(tx);
            return receipt;
        }

        const createGiveaway = async (title: string, amount: number) => {
            const tx = giveoutClient.createTransaction({
                method: { name: "create-giveaway", args: [title, `u${amount}`] },
            });
            await tx.sign("ST1B6H4JPKP37CHBWW5R8KWV4PPZQBXM81YBBB71C");
            const receipt = await giveoutClient.submitTransaction(tx);
            return receipt;
        }
        before(async () => {
            await giveoutClient.deployContract();
        });

        it("should start at zero", async () => {
            const giveawayId = await getGiveawayNonce();
            assert.equal(giveawayId, 0);
        })

        it("should create a giveaway", async () => {
            const giveawayId = await getGiveawayNonce();
            const createdGiveaway = await createGiveaway("hello giveaway", 1000);

            if (createdGiveaway.success) {
                console.log(createdGiveaway);
                assert.equal(createdGiveaway, giveawayId);

            } else {
                throw new Error(createdGiveaway.error);
            }

        })

        it("should increment the ID nonce after a giveaway is created", async () => {
            const createdGiveaway = await createGiveaway("hello giveaway", 1000);

            if (createdGiveaway.success) {
                console.log(createdGiveaway);
                const giveawayNonce = await getGiveawayNonce();
                assert.equal(giveawayNonce, createdGiveaway + 1);

            } else {
                throw new Error(createdGiveaway.error);
            }

        })
    });
    after(async () => {
        await provider.close();
    });
});
